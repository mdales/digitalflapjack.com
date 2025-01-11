open Webplats

let months = [| "Jan" ; "Feb" ; "Mar" ; "Apr" ; "May" ; "Jun" ; "Jul" ; "Aug" ; "Sep" ; "Oct" ; "Nov"; "Dec" |]
  
let ptime_to_str (t : Ptime.t) : string = 
  let ((year, month, day), _) = Ptime.to_date_time t in
  Printf.sprintf "%d %s %d" day months.(month - 1) year
  
let render_section site sec =
  <html>
  <%s! Render.render_head ~site () %>
  <body>
    <div class="almostall">
        <div class="greenbar" id="topbar"></div>
        <div class="page">
          <%s! Renderer.render_header (Section.url sec) (Section.title sec) %>
          <div class="content">
            <section role="main">
              <div class="blogcontents">
% (Section.pages sec) |> List.iter begin fun (page) ->
              <div class="blogcontents__item">
                <ul class="leaders">
                    <li>
                      <span><a href="<%s Section.url ~page sec %>"><%s Page.title page %></a></span>
                      <span><%s ptime_to_str (Page.date page) %></span>
                    </li>
                </ul>
                <div class="blogcontents__item__inner">
                  <div>
                      <p><%s (match (Page.synopsis page) with None -> "" | Some p -> p) %></p>
                  </div>
                </div>
              </div>
% end;
              </div>
            </section>
          </div>
          <div id="footer">
          </div>
        </div>
        <div class="greenbar" id="bottombar">
          <span>Digital Flapjack Ltd, UK Company 06788544</span>
        </div>
      </div>
    </div>
  </body>
  </html>
