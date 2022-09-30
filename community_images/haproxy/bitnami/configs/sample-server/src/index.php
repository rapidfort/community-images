<?php

$routes = [];

route('/', function () {
    echo "My container IP is ", $_SERVER['SERVER_ADDR'];
});

route('/app1', function () {
    echo "My container IP is ", $_SERVER['SERVER_ADDR'];
});

route('/app2', function () {
    echo "My container IP is ", $_SERVER['SERVER_ADDR'];
});

route('/404', function () {
  echo "Page not found";
});

function route(string $path, callable $callback) {
  global $routes;
  $routes[$path] = $callback;
}

run();

function run() {
  global $routes;
  $uri = $_SERVER['REQUEST_URI'];
  $found = false;
  foreach ($routes as $path => $callback) {
    if ($path !== $uri) continue;

    $found = true;
    $callback();
  }

  if (!$found) {
    $notFoundCallback = $routes['/404'];
    $notFoundCallback();
  }
}