const visitorCountElement = document.getElementById("visitor-count");
const isLocalSite = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";
const visitorCountApiUrl = isLocalSite
  ? "http://localhost:7071/api/visitor-count"
  : "https://func-hm-crc-eaene9aufsf4cmen.uaenorth-01.azurewebsites.net/api/visitor-count";

if (visitorCountElement) {
  fetch(visitorCountApiUrl)
    .then(function (response) {
      return response.json();
    })
    .then(function (data) {
      visitorCountElement.textContent = data.visitor_count;
    })
    .catch(function () {
      visitorCountElement.textContent = "--";
    });
}
