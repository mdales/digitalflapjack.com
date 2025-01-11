open Webplats

let months = [| "Jan" ; "Feb" ; "Mar" ; "Apr" ; "May" ; "Jun" ; "Jul" ; "Aug" ; "Sep" ; "Oct" ; "Nov"; "Dec" |]
  
let ptime_to_str (t : Ptime.t) : string = 
  let ((year, month, _day), _) = Ptime.to_date_time t in
  Printf.sprintf "%s %d" months.(month - 1) year
  
let render_section site sec =
  <html>
  <%s! Render.render_head ~site () %>
  <body>
    <div class="almostall">
        <div class="greenbar" id="topbar"></div>
        <div class="page">
          <%s! Renderer.render_header (Section.url sec) (Section.title sec) %>
          <div id="content">
                <h1>Papers and Publications</h1>
                <div class="paperslist">
% (List.iter (fun page ->
% let authorslist = Page.get_key_as_yaml page "authors" in
                        <div class="paper">
                            <p>
                                <span class="title"><%s Page.title page %></span><br/>
                                <span class="authors">
% (match authorslist with Some yaml ->
%   (match yaml with `A lst ->
%     (List.iter (fun yamldict ->
%       (match yamldict with `O assoc ->
%         (match (List.assoc_opt "name" assoc) with Some nameval ->
%           (match nameval with `String name ->
                                <%s name %>
%           | _ -> ());
%         | None -> ());
%       | _ -> ());
%     ) lst);
%   | _ -> ());
% | None -> ());
                                </span><br/>
% (match (Page.get_key_as_string page "type") with Some pubtype ->
                                <%s pubtype %>
% | None -> ());

% (match (Page.get_key_as_string_dict page "conference") with
%  | [] -> (
%   (match (Page.get_key_as_string_dict page "where") with [] ->
    published on

%   | where -> (
%   let url = List.assoc "url" where in
          on <a href="<%s url %>"><%s List.assoc "title" where %></a>,
%   ));
% )
% | conf -> (
%   let title = List.assoc "title" conf in
%   (match (List.assoc_opt "url" conf) with Some url ->
                                        in <a href="<%s url %>"><%s title %></a>,
%    | None ->
      <%s title %>
%   );
% ));
    <%s ptime_to_str (Page.date page) %><br/>

% (match (Page.get_key_as_string page "paper") with Some url ->
    | <a href="<%s url %>">Download</a>
% | None -> ());
% (match (Page.get_key_as_string page "poster") with Some url ->
    | <a href="<%s url %>">Poster</a>
% | None -> ());
% (match (Page.get_key_as_string page "online") with Some url ->
    | <a href="<%s url %>">Online</a>
% | None -> ());
                            </p>
                        </div>
% ) (Section.pages sec));
                </div>
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
