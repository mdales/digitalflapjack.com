open Webplats

let months = [| "Jan" ; "Feb" ; "Mar" ; "Apr" ; "May" ; "Jun" ; "Jul" ; "Aug" ; "Sep" ; "Oct" ; "Nov"; "Dec" |]

let ptime_to_str (t : Ptime.t) : string =
  let ((year, month, _), _) = Ptime.to_date_time t in
  Printf.sprintf "%s %d" months.(month - 1) year

let render_section site sec =
  <html>
  <%s! Render.render_head ~site () %>
  <body>
    <div class="almostall">
        <div class="greenbar" id="topbar"></div>
        <div class="page">
          <%s! Renderer.render_header (Section.url (Site.toplevel site)) (Section.title (Site.toplevel site)) %>
          <div id="content">
            <div class="projectlist">
% (List.iter (fun page ->
% let icon = Page.get_key_as_string page "icon" in
% let src = Page.get_key_as_string page "source" in
% let content = Page.get_key_as_bool page "content" in
% let has_content = match content with None -> false | Some x -> x in
% let has_source = match src with None -> false | Some _ -> true in
              <div class="project">
% (match (has_source || has_content) with true ->
                <a
% (match src with Some url ->
                  href="<%s url %>"
% | None ->
                  href="<%s Section.url ~page sec %>"
% );
                >
% | false -> ());

                  <div>
% (match icon with Some filename ->
% let _, ext = Fpath.split_ext (Fpath.v filename) in
% (match ext with ".svg" ->
                    <div class="projecticon" style="background-image: url('<%s Section.url ~page sec %>thumbnail.svg');"></div>
% | _ -> (
                    <img class="projecticon" src="<%s Section.url ~page sec %>thumbnail.jpg" srcset="<%s Section.url ~page sec %>thumbnail@2x.jpg 2x, <%s Section.url ~page sec %>thumbnail.jpg 1x"/>
% ));
% | None -> (
                  <div class="projecticon"></div>
%));
                </div>
                <h2><%s Page.title page %></h2>
                <p class="projectdate"><%s ptime_to_str (Page.date page) %></p>
                <p>
% (match (Page.synopsis page) with Some prose ->
                  <%s prose %>
% | None -> ());
                </p>


% (match (has_source || has_content) with true ->
                </a>
% | false -> ());
              </div>
% ) (Section.pages sec));
            </div>
          </div>
          <div id="footer">
          </div>
        </div>
      <div class="greenbar" id="bottombar">
        <!-- <span>Digital Flapjack Ltd, UK Company 06788544</span> -->
      </div>
    </div>
  </body>
  </html>
