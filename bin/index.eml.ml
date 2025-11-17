open Webplats

let months = [| "Jan" ; "Feb" ; "Mar" ; "Apr" ; "May" ; "Jun" ; "Jul" ; "Aug" ; "Sept" ; "Oct" ; "Nov"; "Dec" |]

let ptime_to_str (t : Ptime.t) : string =
  let ((year, month, day), _) = Ptime.to_date_time t in
  Printf.sprintf "%d %s %d" day months.(month - 1) year

let page_is_highlight page =
  match (Page.get_key_as_bool page "highlight") with
  | None -> false
  | Some x -> x

let render_index site =
  <html>
  <%s! Render.render_head ~site () %>
  <body>
    <div class="almostall">
        <div class="greenbar" id="topbar"></div>
        <div class="page">
          <%s! Renderer.render_header (Section.uri (Site.toplevel site)) (Section.title (Site.toplevel site)) %>
          <div class="content">
            <div class="article">

            <h2>Intro</h2>
            <p>I'm Michael, and I'm a technologist and maker that's interested in building things that help make the world a better place for people.</p>

            <h2>Highlights</h2>
            <ul>
% let sections = Site.sections site in
% let pages = List.concat_map (fun sec -> Section.pages sec |> List.map (fun p -> (sec, p))) sections in
% let highlights = List.filter (fun (_, p) -> page_is_highlight p) pages in
% List.iter (fun (sec, page) ->
    <li><a href="<%s Uri.to_string (Section.uri ~page sec) %>"><%s Page.title page %><br/></a></li>
% ) highlights;
            </ul>
            </div>
          </div>
        </div>
        <div class="greenbar" id="bottombar">
          <!-- <span>Digital Flapjack Ltd, UK Company 06788544</span> -->
        </div>
      </div>
    </div>
  </body>
  </html>
