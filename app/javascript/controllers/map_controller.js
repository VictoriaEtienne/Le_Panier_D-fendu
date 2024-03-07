import { Controller } from "@hotwired/stimulus";
import mapboxgl from 'mapbox-gl';
// import MapboxDirections from "@mapbox/mapbox-gl-directions"

export default class extends Controller {
  static values = {
    center: Array,
    zoom: Number,
    markers: Array,
    token: String,
    path: Boolean,
    pathOptions: Object,
    pathCoordinates: Array,
  };

  connect() {
    mapboxgl.accessToken = this.tokenValue;

    this.map = new mapboxgl.Map({
      container: this.element, // l'élément container
      style: 'mapbox://styles/mapbox/streets-v11', // style de la carte
      center: this.centerValue, // centre de la carte
      zoom: this.zoomValue, // zoom de la carte
    });

    if (this.markersValue.length > 0) {
      this._addMarkers();
      this._fitMapToMarkers();
    }

    this.map.on('load', () => {
      if (this.pathValue) {
        this._addPath();
      }
    });
  }

  _addMarkers() {
    this.markersValue.forEach((marker) => {
      new mapboxgl.Marker().setLngLat(marker).addTo(this.map);
    });
  }

  _fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();

    this.markersValue.forEach((marker) => {
      bounds.extend(marker);
    });

    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15 });
  }

  _addPath() {
    // Vérifiez si les marqueurs sont présents
    if (this.markersValue.length < 2) {
      return; // Besoin d'au moins deux marqueurs pour tracer un chemin
    }

    // Créer un objet GeoJSON pour le chemin
    const pathGeoJSON = {
      type: 'Feature',
      properties: {},
      geometry: {
        type: 'LineString',
        coordinates: this.pathCoordinatesValue || this.markersValue,
      },
    };

    // Ajouter l'objet GeoJSON en tant que source sur la carte
    this.map.addSource('path', {
      type: 'geojson',
      data: pathGeoJSON,
    });

    // Ajouter une couche pour le chemin
    this.map.addLayer({
      id: 'path',
      type: 'line',
      source: 'path',
      layout: {
        'line-join': 'round',
        'line-cap': 'round',
      },
      paint: {
        'line-color': this.pathOptionsValue.line_color || '#000', // Choisissez une couleur pour le chemin
        'line-width': this.pathOptionsValue.line_width || 5, // Choisissez une largeur de ligne pour le chemin
      },
    });
  }
}
