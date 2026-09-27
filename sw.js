/**
 * Copyright 2018 Google Inc. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// If the loader is already loaded, just stop.
if (!self.define) {
  let registry = {};

  // Used for `eval` and `importScripts` where we can't get script URL by other means.
  // In both cases, it's safe to use a global var because those functions are synchronous.
  let nextDefineUri;

  const singleRequire = (uri, parentUri) => {
    uri = new URL(uri + ".js", parentUri).href;
    return registry[uri] || (
      
        new Promise(resolve => {
          if ("document" in self) {
            const script = document.createElement("script");
            script.src = uri;
            script.onload = resolve;
            document.head.appendChild(script);
          } else {
            nextDefineUri = uri;
            importScripts(uri);
            resolve();
          }
        })
      
      .then(() => {
        let promise = registry[uri];
        if (!promise) {
          throw new Error(`Module ${uri} didn’t register its module`);
        }
        return promise;
      })
    );
  };

  self.define = (depsNames, factory) => {
    const uri = nextDefineUri || ("document" in self ? document.currentScript.src : "") || location.href;
    if (registry[uri]) {
      // Module is already loading or loaded.
      return;
    }
    let exports = {};
    const require = depUri => singleRequire(depUri, uri);
    const specialDeps = {
      module: { uri },
      exports,
      require
    };
    registry[uri] = Promise.all(depsNames.map(
      depName => specialDeps[depName] || require(depName)
    )).then(deps => {
      factory(...deps);
      return exports;
    });
  };
}
define(['./workbox-7e5eb42b'], (function (workbox) { 'use strict';

  self.skipWaiting();
  workbox.clientsClaim();
  /**
   * The precacheAndRoute() method efficiently caches and responds to
   * requests for URLs in the manifest.
   * See https://goo.gl/S9QRab
   */
  workbox.precacheAndRoute([{
    "url": "registerSW.js",
    "revision": "402b66900e731ca748771b6fc5e7a068"
  }, {
    "url": "pwa-maskable-512x512.png",
    "revision": "4714a129bd0c7d0b120e6ef6faf1a0a3"
  }, {
    "url": "pwa-512x512.png",
    "revision": "932426c6ef6c4c6f914222a05b0193f6"
  }, {
    "url": "pwa-192x192.png",
    "revision": "7e7cdb87c473269c040cc8a65f17d12b"
  }, {
    "url": "index.html",
    "revision": "b79f1d7dc2f0ae8f3a97607561fde289"
  }, {
    "url": "icon.svg",
    "revision": "aee5622e3ae976e07dc4e42631e4ec5b"
  }, {
    "url": "favicon.ico",
    "revision": "1ed8147bc6645d9bf67dc77eff573271"
  }, {
    "url": "apple-touch-icon.png",
    "revision": "8a58b7ff349a39867e524c36d91c0a30"
  }, {
    "url": "assets/index-Csu5Sy6-.js",
    "revision": null
  }, {
    "url": "assets/index-B5M72TwE.css",
    "revision": null
  }, {
    "url": "apple-touch-icon.png",
    "revision": "8a58b7ff349a39867e524c36d91c0a30"
  }, {
    "url": "favicon.ico",
    "revision": "1ed8147bc6645d9bf67dc77eff573271"
  }, {
    "url": "icon.svg",
    "revision": "aee5622e3ae976e07dc4e42631e4ec5b"
  }, {
    "url": "pwa-192x192.png",
    "revision": "7e7cdb87c473269c040cc8a65f17d12b"
  }, {
    "url": "pwa-512x512.png",
    "revision": "932426c6ef6c4c6f914222a05b0193f6"
  }, {
    "url": "pwa-maskable-512x512.png",
    "revision": "4714a129bd0c7d0b120e6ef6faf1a0a3"
  }, {
    "url": "manifest.webmanifest",
    "revision": "0f67db1976d7f6e8574941a9cae7b506"
  }], {});
  workbox.cleanupOutdatedCaches();
  workbox.registerRoute(new workbox.NavigationRoute(workbox.createHandlerBoundToURL("index.html")));

}));
