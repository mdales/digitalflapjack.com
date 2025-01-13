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


let render_page site sec previous_page page next_page =
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
                  <h1 class="title"><%s Page.title page %></h1>
                  <p class="date"><%s ptime_to_str (Page.date page) %></p>
% (match (Page.tags page) with [] -> () | tags -> (
                  <p>Tags:
% let count = (List.length tags) - 1 in
% (List.iteri (fun i tag ->
% let term_for_url = String.map (fun c -> match c with ' ' -> '-' | x -> x) tag in
% let seperator = if (i < count) then "," else "" in
                <a href="/tags/<%s term_for_url %>/"><%s tag %></a><%s seperator %>
% ) tags);
                </p>
% ));

                  <div class="content">
                    <%s! Render.render_body page %>
                  </div>
                </article>

                <div class="paginationflex">
% (match previous_page with Some page ->
                  <a href="<%s Section.url ~page sec %>">&#10094; <%s Page.title page %></a>
% | None -> (
                  <span></span>
% ));
% (match next_page with Some page ->
                  <a href="<%s Section.url ~page sec %>"><%s Page.title page %> &#10095;</a>
% | None -> ());
                </div>
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
