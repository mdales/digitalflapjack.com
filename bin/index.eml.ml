open Webplats

let months = [| "Jan" ; "Feb" ; "Mar" ; "Apr" ; "May" ; "Jun" ; "Jul" ; "Aug" ; "Sept" ; "Oct" ; "Nov"; "Dec" |]

let ptime_to_str (t : Ptime.t) : string = 
  let ((year, month, day), _) = Ptime.to_date_time t in
  Printf.sprintf "%d %s %d" day months.(month - 1) year
  
let render_index site =
  <html>
  <%s! Render.render_head ~site () %>
  <body>
    <div class="almostall">
        <div class="greenbar" id="topbar"></div>
        <div class="page">
          <%s! Renderer.render_header (Section.url (Site.toplevel site)) (Section.title (Site.toplevel site)) %>
          <div class="content">
            <div class="index">

% (Site.sections site) |> List.filter (fun s -> "blog" = (Section.title s)) |> List.iter begin fun (sec) ->
              <div class="article index-<%s Section.title sec %>">
                <article>
                    <h3><a href="<%s Section.url sec %>">Recent posts</a></h3>
                    <ul>
% (List.iter (fun page ->
                      <li>
                        <div class="summarylistitem">
                            <div>
                                <a href="<%s Section.url ~page sec %>"
                                    ><span class="itemtitle"><%s Page.title page %></span
                                    ><br />
                                    <div class="synopsis">
% (match (Page.synopsis page) with Some prose ->
                                        <%s prose %>
% | None -> ());
                                    </div></a
                                >
                            </div>
                            <div>
% (match (Page.titleimage page) with Some img ->
% let _, ext = Fpath.split_ext (Fpath.v img.filename) in
% (match ext with ".svg" ->
                              <div class="indexicon"
                                style="background-image: url('<%s Section.url ~page sec %>thumbnail.svg');"
                              ></div>
% | _ -> (
                              <img
                                src="<%s Section.url ~page sec %>thumbnail.jpg"
                                srcset="<%s Section.url ~page sec %>thumbnail@2x.jpg 2x, <%s Section.url ~page sec %>thumbnail.jpg 1x"
                              />
% ));
% | None -> ());
                            </div>
                        </div>
                      </li>
% ) (Section.pages sec));
                      <li class="indexmore"><a href="<%s Section.url sec %>">See more...</a></li>
                    </ul>
                </article>
              </div>
% end;
            </div>
          </div>
        </div>
        <div class="greenbar" id="bottombar">
          <span>Digital Flapjack Ltd, UK Company 06788544</span>
        </div>
      </div>  
    </div>
  </body>
  </html>
