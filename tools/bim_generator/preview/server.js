/**
 * Local GLB preview — open http://localhost:4177/?model=earthbag_masonry
 */
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 4177;
const root = path.join(__dirname, '..', 'generated_models');

const html = `<!DOCTYPE html>
<html><head><meta charset="utf-8"/><title>RBP BIM Preview</title>
<script type="importmap">{"imports":{"three":"https://unpkg.com/three@0.170.0/build/three.module.js","three/addons/":"https://unpkg.com/three@0.170.0/examples/jsm/"}}</script>
<style>body{margin:0;background:#e8eef4;font-family:system-ui}#info{position:absolute;top:12px;left:12px;background:#0f172acc;color:#fff;padding:12px;border-radius:8px}</style>
</head><body>
<div id="info">Loading…</div>
<script type="module">
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
const params = new URLSearchParams(location.search);
const model = params.get('model') || 'interlocking_brick_masonry';
const stage = params.get('stage') || 'construction_master';
const info = document.getElementById('info');
info.textContent = model + ' / ' + stage;
const scene = new THREE.Scene();
scene.background = new THREE.Color(0xe8eef4);
const camera = new THREE.PerspectiveCamera(50, innerWidth/innerHeight, 0.1, 200);
camera.position.set(8, 5, 8);
const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(innerWidth, innerHeight);
document.body.appendChild(renderer.domElement);
const controls = new OrbitControls(camera, renderer.domElement);
scene.add(new THREE.AmbientLight(0xffffff, 0.65));
const dir = new THREE.DirectionalLight(0xffffff, 0.85);
dir.position.set(5, 10, 7);
scene.add(dir);
const loader = new GLTFLoader();
loader.load('/models/' + model + '/' + stage + '.glb', (g) => {
  scene.add(g.scene);
  const box = new THREE.Box3().setFromObject(g.scene);
  const c = box.getCenter(new THREE.Vector3());
  controls.target.copy(c);
}, undefined, (e) => { info.textContent = 'Load error: ' + e; });
function animate(){ requestAnimationFrame(animate); controls.update(); renderer.render(scene, camera); }
animate();
window.addEventListener('resize', () => {
  camera.aspect = innerWidth/innerHeight; camera.updateProjectionMatrix();
  renderer.setSize(innerWidth, innerHeight);
});
</script></body></html>`;

const server = http.createServer((req, res) => {
  if (req.url === '/' || req.url.startsWith('/?')) {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(html);
    return;
  }
  if (req.url.startsWith('/models/')) {
    const rel = req.url.replace('/models/', '');
    const file = path.join(root, rel);
    if (fs.existsSync(file)) {
      res.writeHead(200, { 'Content-Type': 'model/gltf-binary' });
      fs.createReadStream(file).pipe(res);
      return;
    }
  }
  res.writeHead(404);
  res.end('Not found');
});

server.listen(PORT, () => console.log(`BIM preview http://localhost:${PORT}/?model=earthbag_masonry&stage=stage_07_complete`));
