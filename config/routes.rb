LocomotiveExporter::Application.routes.draw do
  match 'admin/exports/new' => 'admin/exports#new'
end
