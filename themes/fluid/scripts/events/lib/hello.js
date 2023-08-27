'use strict';

module.exports = (hexo) => {
  if (hexo.theme.has_hello) {
    return;
  }

  if (hexo.theme.i18n.languages[0].search(/zh-CN/i) !== -1) {
    hexo.log.info(`
   _  __   _               ____   ___    ____
  | |/_/  (_)  ___  ____  / __/  / _ |  / __/
 _>  <   / /  / _ \\/___/ / _/   / __ | _\\ \\
/_/|_|  /_/  /_//_/     /_/    /_/ |_|/___/
    `);
  } else {
    hexo.log.info(`
   _  __   _               ____   ___    ____
  | |/_/  (_)  ___  ____  / __/  / _ |  / __/
 _>  <   / /  / _ \\/___/ / _/   / __ | _\\ \\
/_/|_|  /_/  /_//_/     /_/    /_/ |_|/___/
    `);
  }

  hexo.theme.has_hello = true;
};
