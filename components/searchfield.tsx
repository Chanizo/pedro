import {useMap} from "react-leaflet";
import {GeoSearchControl, OpenStreetMapProvider} from "leaflet-geosearch";
import {useEffect} from "react";

export default function SearchField() {
    const map = useMap()

    useEffect(() => {
        const provider = new OpenStreetMapProvider();

        const searchControl = new GeoSearchControl({
            provider,
            style: 'bar',
        });

        map.addControl(searchControl);

        return () => {
            map.removeControl(searchControl);
        };
    }, [map]);

    return null;
}
