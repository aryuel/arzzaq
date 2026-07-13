import { createApp, h, type App } from 'vue';

export const mountApplication = (selector = '#app'): App<Element> | null => {
    const target = document.querySelector(selector);

    if (target === null) {
        return null;
    }

    const application = createApp({
        name: 'ArzzaqBootstrap',
        render: () => h('div', { 'data-application-ready': 'true' }),
    });

    application.mount(target);

    return application;
};

mountApplication();
