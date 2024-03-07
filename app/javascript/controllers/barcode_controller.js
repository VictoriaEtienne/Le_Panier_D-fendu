import { Controller } from "@hotwired/stimulus";
import Quagga from '@ericblade/quagga2';

export default class extends Controller {
  connect() {
    console.log(Quagga);
    this.scanner = Quagga.init({
      inputStream: {
        name: "Live",
        type: "LiveStream",
        constraints: {
          width: 640,
          height: 480,
          facingMode: "environment",
        },
        locator: {
          patchSize: "medium",
          halfSample: true
        },
        area: {
          top: "10%",
          right: "10%",
          left: "10%",
          bottom: "10%",
        },
        singleChannel: false,
        target: this.element
      },
      decoder: {
        readers: [
          "code_128_reader"
        ]
      }
    }, (err) => {
      if (err) {
        console.log(err);
        return;
      }
      console.log("Initialization finished. Ready to start");
      Quagga.start();
    });
    Quagga.onDetected(this.handleDetection.bind(this));
  }

  handleDetection(data) {
    console.log(data.codeResult.code);
    Quagga.stop()
    const form = document.getElementById('barcodeForm');
    const barcodeInput = document.getElementById('barcodeInput');
    barcodeInput.value = data.codeResult.code;
    console.log("Code-barres détecté:", data.codeResult.code);

    fetch(`/product_alternatives/search?bar_code=${data.codeResult.code}`)
      .then(response => response.json())
      .then((data) => {
        console.log(data);
      })
      .catch(error => {
        console.error('Erreur lors de la requête fetch:', error);
      });

    // const event = new CustomEvent('barcodeDetected', { detail: { code: data.codeResult.code } });
    // window.dispatchEvent(event);
    // form.submit();
  }

}
