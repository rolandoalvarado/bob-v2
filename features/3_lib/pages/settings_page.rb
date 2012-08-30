require_relative 'secure_page'

class SettingsPage < SecurePage
  path '/current_user'

  button 'create keypair',              '#new-keypair'
  button 'import keypair',              '#import-keypair'

  form   'create keypair',              '#create-keypair-modal'
  field  'keypair name',                '#new-keypair-name'
  field  'keypair public key',          '#new-keypair-pubkey'
  button 'create keypair confirmation', '#create-keypair'

  form   'keypair',                     '#keypair-modal'
  field  'keypair private key',         '#new-keypair-privkey'

  table  'keypairs',                    '#keypair-list'
  row    'keypair',                     '#keypair-item-<id>'
  button 'delete keypair',              '#keypair-item-<id> .delete-keypair'
end
