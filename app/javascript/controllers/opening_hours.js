// Définition d'une fonction pour vérifier si le magasin est ouvert en fonction de ses heures d'ouverture
function isShopOpen(openingHours) {
  // Récupération de la date et de l'heure actuelles
  const now = new Date();
  // Récupération du jour actuel de la semaine au format long (par exemple, "Monday", "Tuesday", etc.)
  const currentDay = now.toLocaleDateString('fr-FR', { weekday: 'long' });
  // Calcul de l'heure actuelle en minutes (heure * 100 + minutes)
  const currentTime = now.getHours() * 100 + now.getMinutes();

  // Vérification si le jour actuel fait partie des jours d'ouverture du magasin
  if (openingHours[currentDay.toLowerCase()]) {
    // Récupération de l'heure d'ouverture et de fermeture du magasin pour le jour actuel
    const { open, close } = openingHours[currentDay.toLowerCase()];
    // Conversion des heures d'ouverture et de fermeture en minutes
    const [openHour, openMinute] = open.split(':').map(Number);
    const [closeHour, closeMinute] = close.split(':').map(Number);
    const openingTime = openHour * 100 + openMinute;
    const closingTime = closeHour * 100 + closeMinute;

    // Vérification si l'heure actuelle est comprise entre l'heure d'ouverture et de fermeture du magasin
    if (currentTime >= openingTime && currentTime <= closingTime) {
      return true; // Le magasin est ouvert
    }
  }
  return false; // Le magasin est fermé
}

// Récupération des éléments HTML des pastilles d'état (ouvert/fermé)
const openBadge = document.querySelector('.open-badge');
const closedBadge = document.querySelector('.closed-badge');

// Appel de la fonction isShopOpen pour vérifier si le magasin est ouvert ou fermé
if (isShopOpen(openingHours)) {
  // Affichage de la pastille "ouvert" en modifiant son style pour être visible
  openBadge.style.display = 'inline-block';
  // Masquage de la pastille "fermé" en modifiant son style pour être invisible
  closedBadge.style.display = 'none';
} else {
  // Affichage de la pastille "fermé" en modifiant son style pour être visible
  openBadge.style.display = 'none';
  // Masquage de la pastille "ouvert" en modifiant son style pour être invisible
  closedBadge.style.display = 'inline-block';
}
