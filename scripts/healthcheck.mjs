import { execFileSync } from 'node:child_process';

const layananWajib = ['app', 'caddy', 'horizon', 'postgres', 'redis', 'reverb', 'scheduler'];
const argumenWait = process.argv.indexOf('--wait');
const batasDetik = argumenWait >= 0 ? Number(process.argv[argumenWait + 1]) : 0;
const mulai = Date.now();

const tunggu = (milidetik) => new Promise((resolve) => setTimeout(resolve, milidetik));

const bacaStatus = () => {
    const output = execFileSync('docker', ['compose', 'ps', '--format', 'json'], {
        encoding: 'utf8',
        stdio: ['ignore', 'pipe', 'pipe'],
    }).trim();

    if (output === '') {
        return [];
    }

    try {
        const hasil = JSON.parse(output);
        return Array.isArray(hasil) ? hasil : [hasil];
    } catch {
        return output.split(/\r?\n/).filter(Boolean).map((baris) => JSON.parse(baris));
    }
};

while (true) {
    const status = bacaStatus();
    const belumSiap = layananWajib.filter((nama) => {
        const layanan = status.find((item) => item.Service === nama);
        return layanan === undefined || layanan.State !== 'running' || layanan.Health !== 'healthy';
    });

    if (belumSiap.length === 0) {
        console.log('Seluruh layanan Arzzaq berjalan dan sehat.');
        break;
    }

    if ((Date.now() - mulai) / 1000 >= batasDetik) {
        throw new Error(`Layanan belum sehat: ${belumSiap.join(', ')}`);
    }

    await tunggu(3000);
}
