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
                        <h3><a href=""><%s Page.title page %></a></h3>
                        <%s! Render.render_body page %>
                        </div>
                        <div id="mepic">
                            <h3>&nbsp;</h3>
                            <img class="aboutme" src="<%s Section.url ~page sec %>thumbnail.jpg" srcset="<%s Section.url ~page sec %>thumbnail@2x.jpg 2x, <%s Section.url ~page sec %>thumbnail.jpg 1x"/>
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
  </body>
  </html>
