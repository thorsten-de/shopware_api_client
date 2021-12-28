alias ShopwareApiClient.Admin

create_customer = fn data ->
  data = data
  |> Map.put(:id, UUID.uuid1(:hex))

  :customer
  |> Admin.create(data)
end

nadja = %{
  #id: "b02c1f6cd3724f069a7aa8313308f534",
  id: UUID.uuid1(:hex),
  groupId: "0f8f9c66cd674a13927ed7663c5f47fc",
  #defaultPaymentMethodId: "5e3a6307c4564507bd688cf4fda1877b",
  #salesChannelId: "c707cba3ad2c427ca861e63729756f66",
  #defaultBillingAddressId: "cbe294f9bee7430da2f7918298800f79",
  #defaultShippingAddressId: "cbe294f9bee7430da2f7918298800f79",
  customerNumber: "123456",
  salutationId: "06c2ba98421c4a7db30551d3bcf71036",
  firstName: "Nadja",
  lastName: "Deinert",
  email: "nadja@thorsten-michael.de",
  vatIds: [],
    tcBerater: %{
      beraternummer: 999999,
      endkundennummer: 666666,
      faktura_linked_at: DateTime.now!()
    },
  addresses: [
      %{
          id: UUID.uuid1(:hex),
          #countryId: "2956b365f73042dba4a234e6b427e36b",
          salutationId: "06c2ba98421c4a7db30551d3bcf71036",
          firstName: "Nadja",
          lastName: "Deinert",
          zipcode: "59348",
          city: "Lüdinghausen",
          street: "Geschwister-Scholl-Str. 13",
          phoneNumber: "015759013374"
      }
  ]
}

berater = %{filter: [%{type: "equals", field: "beraternummer", value: 100007}]}
