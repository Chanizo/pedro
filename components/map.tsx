'use client';


import 'leaflet/dist/leaflet.css';
import 'leaflet-geosearch/dist/geosearch.css';
import 'leaflet-defaulticon-compatibility/dist/leaflet-defaulticon-compatibility.webpack.css';
import 'leaflet-geosearch/dist/geosearch.css';
import 'leaflet-routing-machine/dist/leaflet-routing-machine.css';

import 'leaflet-defaulticon-compatibility';

import {GeoJSON, MapContainer, TileLayer} from 'react-leaflet'
import RoutingMachine from "@/components/routingmachine";
import {LatLng} from "leaflet";
import {useEffect, useState} from "react";


export default function MyMap() {
  const maisonDePedro = [43.952575, 4.807580] as LatLng;
  const [geojsonData, setGeojsonData] = useState(null);

  useEffect(() => {
    fetch('/data/aoc-pedro-exo.geojson')
      .then(response => response.json())
      .then(data => {
        setGeojsonData(data)
      })
      .catch(error => console.error('Erreur lors du chargement du fichier GeoJSON:', error));
  }, []);

  if (!geojsonData) {
    return <p>En attente</p>
  }


  return (
    <MapContainer center={maisonDePedro} zoom={16} scrollWheelZoom={true} touchZoom={true}>
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      {geojsonData && <GeoJSON data={geojsonData} style={{
        color: 'blue',
        weight: 2,
        opacity: 0.6,
        fillColor: 'blue',
        fillOpacity: 0.3
      }}/>}
      <RoutingMachine start={maisonDePedro}/>
    </MapContainer>
  )
}
