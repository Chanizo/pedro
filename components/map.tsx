'use client';


import 'leaflet/dist/leaflet.css';
import 'leaflet-defaulticon-compatibility/dist/leaflet-defaulticon-compatibility.webpack.css';

import 'leaflet-defaulticon-compatibility';

import {MapContainer, TileLayer} from 'react-leaflet'
import {LatLng} from "leaflet";


export default function MyMap() {
  const maisonDePedro = [43.952575, 4.807580] as LatLng;

  return (
    <MapContainer center={maisonDePedro} zoom={16} scrollWheelZoom={true} touchZoom={true}>
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
    </MapContainer>
  )
}
