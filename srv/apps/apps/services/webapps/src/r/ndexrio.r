#' @export
ui_ndexrio <- function(id, request) {
  box::use(
    shiny = shiny[tags],
    . / head / head,
    . / body / body,
    . / ndexrio
  )

  ns <- shiny$NS(id)

  http_headers <- data.frame(
    timestamp = Sys.time(),
    HTTP_X_REAL_IP = ifelse(is.null(request$HTTP_X_REAL_IP), "", request$HTTP_X_REAL_IP)
  )
  
  tags$html(
    head$ui_head(stylesheet='./css/ndexrio.css'),
    tags$body(
      id = ns("body"),
      class = "ndexrconsole",
        tags$div(class = "container",
          tags$div(
            class = "row",
            tags$div(
              class = "col text-center",
              tags$h3("ndexr"),
              tags$div(
                tags$code(jsonlite::toJSON(http_headers, pretty = TRUE))
              )
            )
          ),
          tags$div(
            class = "bouncing-emoji",
            tags$a(
              href = "https://console.ndexr.io",
              tags$span("😊", class = "mirror")
            )
          )
      ),
      tags$style(shiny$HTML("
      body, html {
          margin: 0;
          padding: 0;
          overflow: hidden;
          background-color: #000; /* Dark background */
      }

      #rainCanvas {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          pointer-events: none; /* Allow clicks to pass through */
      }
    ")),
      tags$script(shiny$HTML("
      // Create and append the canvas element
      const canvas = document.createElement('canvas');
      canvas.id = 'rainCanvas';
      document.body.appendChild(canvas);

      // Rainfall effect JavaScript
      const ctx = canvas.getContext('2d');

      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;

      const raindrops = [];
      const numRaindrops = 100;

      class Raindrop {
          constructor(x, y, length, speed) {
              this.x = x;
              this.y = y;
              this.length = length;
              this.speed = speed;
          }

          update() {
              this.y += this.speed;
              if (this.y > canvas.height) {
                  this.y = -this.length;
              }
          }

          draw() {
              ctx.beginPath();
              ctx.moveTo(this.x, this.y);
              ctx.lineTo(this.x, this.y + this.length);
              ctx.strokeStyle = 'rgba(255, 255, 255, 0.5)'; // Light color for raindrops
              ctx.lineWidth = 1;
              ctx.stroke();
          }
      }

      function initRaindrops() {
          for (let i = 0; i < numRaindrops; i++) {
              const x = Math.random() * canvas.width;
              const y = Math.random() * canvas.height;
              const length = Math.random() * 20 + 10;
              const speed = Math.random() * 3 + 2;
              raindrops.push(new Raindrop(x, y, length, speed));
          }
      }

      function animate() {
          ctx.clearRect(0, 0, canvas.width, canvas.height);
          raindrops.forEach(drop => {
              drop.update();
              drop.draw();
          });
          requestAnimationFrame(animate);
      }

      initRaindrops();
      animate();

      window.addEventListener('resize', () => {
          canvas.width = window.innerWidth;
          canvas.height = window.innerHeight;
      });
    "))
    )
  )
}

#' @export
server_ndexrio <- function(id) {
  box::use(shiny = shiny[withTags, tags],  . / body / body, utils)

  shiny$moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      body$server_body("body")

    }
  )
}
