import * as L from 'leaflet';
import 'leaflet-routing-machine';
import 'leaflet-control-geocoder';
import { createControlComponent } from "@react-leaflet/core";
import { useMapEvent, useMap } from 'react-leaflet';
import { useState } from 'react';

// Define custom icons for start and end markers
const startIcon = new L.Icon({
    iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png', // Replace with the URL or local path to your blue marker
    iconSize: [25, 41], // Size of the icon
    iconAnchor: [12, 41], // Anchor point of the icon
    popupAnchor: [1, -34],
    shadowSize: [41, 41],
});

const endIcon = new L.Icon({
    iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png', // Replace with the URL or local path to your red marker
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34],
    shadowSize: [41, 41],
});

const createRoutineMachineLayer = ({ waypoints }: { waypoints: L.LatLng[] }) => {
    const instance = L.Routing.control({
        waypoints: waypoints,
        geocoder: L.Control.Geocoder.nominatim(),
        routeWhileDragging: true,
        createMarker: function (i, waypoint, n) {
            // Use the custom icons for start and end
            if (i === 0) {
                return L.marker(waypoint.latLng, { icon: startIcon, draggable: true});
            } else if (i === n - 1) {
                return L.marker(waypoint.latLng, { icon: endIcon, draggable: true});
            }
            return L.marker(waypoint.latLng);
        }
    });

    return instance;
};

const RoutingMachine = ({ start, end }: { start: L.LatLng }) => {
    const [waypoints, setWaypoints] = useState<L.LatLng[]>([start]);
    const map = useMap();

    // Add click event to map to update waypoints
    useMapEvent('click', (e) => {
        const newWaypoint = e.latlng;

        // Create a Leaflet popup
        const popup = L.popup()
            .setLatLng(newWaypoint)
            .setContent(`
                <div>
                    <button id="setStart" style="margin-right: 5px;">Set Start</button>
                    <button id="setEnd">Set End</button>
                </div>
            `)
            .openOn(map);

        // Add event listeners to the buttons
        popup.getElement()?.querySelector('#setStart')?.addEventListener('click', () => {
            const updatedWaypoints = [newWaypoint, waypoints[1]]; // Update start
            setWaypoints(updatedWaypoints);
            map.closePopup();
        });

        popup.getElement()?.querySelector('#setEnd')?.addEventListener('click', () => {
            const updatedWaypoints = [waypoints[0], newWaypoint]; // Update end
            setWaypoints(updatedWaypoints);
            map.closePopup();
        });
    });

    const RoutingMachineLayer = createControlComponent(() => createRoutineMachineLayer({ waypoints }));

    return <RoutingMachineLayer />;
};

export default RoutingMachine;
