class AddImgUrlToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :img_url, :string
  end
end
