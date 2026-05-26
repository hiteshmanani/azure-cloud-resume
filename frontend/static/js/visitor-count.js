const visitorCountElement = document.getElementById("visitor-count");
const isLocalSite = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";

if (visitorCountElement && isLocalSite) {
  fetch("http://localhost:7071/api/visitor-count")
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
