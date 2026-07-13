import { execFileSync } from 'node:child_process';

const layananWajib = ['app', 'caddy', 'horizon', 'postgres', 'redis', 'reverb', 'scheduler'];

const gagal = (pesan) => {
    throw new Error(`Validasi infrastruktur gagal: ${pesan}`);
};

let konfigurasi;

try {
    const composeBin = process.env.DOCKER_COMPOSE_BIN;
    const executable = composeBin ?? 'docker';
    const args = composeBin === undefined
        ? ['compose', 'config', '--format', 'json']
        : ['config', '--format', 'json'];

    konfigurasi = JSON.parse(
        execFileSync(executable, args, {
            encoding: 'utf8',
            stdio: ['ignore', 'pipe', 'pipe'],
        }),
    );
} catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    gagal(`Docker Compose tidak dapat menghasilkan konfigurasi: ${detail}`);
}

for (const nama of layananWajib) {
    const layanan = konfigurasi.services?.[nama];

    if (layanan === undefined) {
        gagal(`layanan ${nama} tidak tersedia`);
    }

    if (layanan.read_only !== true) {
        gagal(`root filesystem ${nama} harus read-only`);
    }

    if (layanan.user === undefined || /^(0|root)(:|$)/.test(String(layanan.user))) {
        gagal(`${nama} harus berjalan sebagai user non-root eksplisit`);
    }

    if (!layanan.security_opt?.includes('no-new-privileges:true')) {
        gagal(`${nama} harus memakai no-new-privileges`);
    }

    if (!layanan.cap_drop?.includes('ALL')) {
        gagal(`${nama} harus melepas seluruh Linux capability`);
    }

    if (layanan.healthcheck === undefined) {
        gagal(`${nama} harus memiliki healthcheck`);
    }

    if (layanan.pids_limit === undefined || Number(layanan.pids_limit) <= 0) {
        gagal(`${nama} harus memiliki PID limit`);
    }

    if (layanan.mem_limit === undefined || Number(layanan.mem_limit) <= 0) {
        gagal(`${nama} harus memiliki memory limit`);
    }
}

const layananDenganPortHost = Object.entries(konfigurasi.services)
    .filter(([, layanan]) => Array.isArray(layanan.ports) && layanan.ports.length > 0)
    .map(([nama]) => nama);

if (layananDenganPortHost.length !== 1 || layananDenganPortHost[0] !== 'caddy') {
    gagal('hanya Caddy yang boleh membuka port host');
}

if (konfigurasi.networks?.data?.internal !== true) {
    gagal('network data harus internal');
}

for (const nama of ['postgres', 'redis']) {
    const jaringan = Object.keys(konfigurasi.services[nama].networks ?? {});

    if (jaringan.length !== 1 || jaringan[0] !== 'data') {
        gagal(`${nama} hanya boleh terhubung ke network data`);
    }
}

for (const nama of ['postgres', 'redis']) {
    const image = konfigurasi.services[nama].image ?? '';

    if (!image.includes('@sha256:')) {
        gagal(`image ${nama} harus dipin dengan digest`);
    }
}

if (JSON.stringify(konfigurasi).includes('/var/run/docker.sock')) {
    gagal('Docker socket tidak boleh dipasang ke container');
}

console.log('Konfigurasi Compose memenuhi baseline isolasi dan hardening Fase 2.');
