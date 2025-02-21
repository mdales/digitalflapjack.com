open Webplats

let render_page site sec _previous_page page _next_page =
  <!DOCTYPE html>
  <html>
  <%s! (Render.render_head ~site ~sec ~page ()) %>
  <body>
    <div class="almostall">
      <div class="greenbar" id="topbar"></div>
      <div class="page">
        <%s! Renderer.render_header (Section.url sec) (Section.title sec) %>
          <div id="content">
              <div class="article">
              <article>
                    <div class="flex">
                        <div id="prose">
                        <h1><%s Page.title page %></h1>
                        <%s! Render.render_body page %>
                        </div>
                        <div id="mepic">
                            <h2>&nbsp;</h2>
                            <img class="aboutme" src="<%s Section.url ~page sec %>thumbnail.jpg" srcset="<%s Section.url ~page sec %>thumbnail@2x.jpg 2x, <%s Section.url ~page sec %>thumbnail.jpg 1x"/>
                            <div id="sidebar">
                              <canvas
                                id="side"
                                width="400px"
                                height="600px"/>
                            </div>
                        </div>
                    </div>
                </article>
              </div>
          </div>
          <div id="footer">
          </div>
      </div>
      <div class="greenbar" id="bottombar">
        <span>Digital Flapjack Ltd, UK Company 06788544</span>
      </div>
    </div>
    <script>
      let start;


      function tick(timestamp) {
        if (start === undefined) {
          start = timestamp;
        }
        const t = timestamp - start;

        const canvas = document.getElementById("side");
        const ctx = canvas.getContext("2d");

        const step = canvas.width / 10;

        ctx.clearRect(0, 0, canvas.width, canvas.height);

        ctx.strokeStyle = "rgb(127 180 0 / 50%)";

        const z = 10 + (Math.sin(t / 100000) * 5);
        const d = 10 + (Math.cos(t / 100000) * 5);

        for (y = 0; y < (canvas.height / step); y ++) {
          for (x = 0; x < (canvas.width / step); x ++) {

            const c = (Math.sin(Math.sin((x + (t / 100)) / z)) +
              Math.sin(Math.sin((y + (t/100)) / d))) * 5;
            const r = (c + 8) / 3;

            if (r > 0) {
              ctx.beginPath();
              ctx.lineWidth = (r / 2);
              ctx.arc(
                (x * step) + (step / 2),
                (y * step) + (step / 2),
                r, 0, Math.PI * 2, 0);
              ctx.stroke();
            }
          }
        }

        window.requestAnimationFrame(tick);
      };


      document.addEventListener('DOMContentLoaded', function(){
        window.requestAnimationFrame(tick);
      });
    </script>
  </body>
  </html>
