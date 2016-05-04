Deface::Override.new(
  name: 'add_marketing_dropdown_to_admin_panel',
  virtual_path: 'spree/layouts/admin',
  insert_bottom: '#main-sidebar',
  partial: 'spree/admin/shared/marketing_tab'
)
