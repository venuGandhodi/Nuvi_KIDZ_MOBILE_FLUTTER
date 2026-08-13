class ShopifyQueries {
  static const String getProducts = r'''
    query GetProducts($first: Int = 20) {
      products(first: $first) {
        edges {
          node {
            id
            title
            handle
            descriptionHtml
            vendor
            productType
            tags
            images(first: 10) {
              edges {
                node {
                  url
                  altText
                }
              }
            }
            variants(first: 50) {
              edges {
                node {
                  id
                  title
                  availableForSale
                  price {
                    amount
                    currencyCode
                  }
                  compareAtPrice {
                    amount
                    currencyCode
                  }
                  selectedOptions {
                    name
                    value
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static const String getProductByHandle = r'''
    query GetProductByHandle($handle: String!) {
      product(handle: $handle) {
        id
        title
        handle
        descriptionHtml
        vendor
        productType
        tags
        images(first: 10) {
          edges {
            node {
              url
              altText
            }
          }
        }
        variants(first: 50) {
          edges {
            node {
              id
              title
              availableForSale
              price {
                amount
                currencyCode
              }
              compareAtPrice {
                amount
                currencyCode
              }
              selectedOptions {
                name
                value
              }
            }
          }
        }
      }
    }
  ''';

  static const String getProductById = r'''
    query GetProductById($id: ID!) {
      node(id: $id) {
        ... on Product {
          id
          title
          handle
          descriptionHtml
          vendor
          productType
          tags
          images(first: 10) {
            edges {
              node {
                url
                altText
              }
            }
          }
          variants(first: 50) {
            edges {
              node {
                id
                title
                availableForSale
                price {
                  amount
                  currencyCode
                }
                compareAtPrice {
                  amount
                  currencyCode
                }
                selectedOptions {
                  name
                  value
                }
              }
            }
          }
        }
      }
    }
  ''';

  static const String getCollections = r'''
    query GetCollections($first: Int = 20) {
      collections(first: $first) {
        edges {
          node {
            id
            title
            handle
            description
            image {
              url
              altText
            }
          }
        }
      }
    }
  ''';

  static const String getCollectionByHandle = r'''
    query GetCollectionByHandle($handle: String!, $firstProducts: Int = 20) {
      collection(handle: $handle) {
        id
        title
        handle
        description
        image {
          url
          altText
        }
        products(first: $firstProducts) {
          edges {
            node {
              id
              title
              handle
              descriptionHtml
              vendor
              productType
              tags
              images(first: 10) {
                edges {
                  node {
                    url
                    altText
                  }
                }
              }
              variants(first: 50) {
                edges {
                  node {
                    id
                    title
                    availableForSale
                    price {
                      amount
                      currencyCode
                    }
                    compareAtPrice {
                      amount
                      currencyCode
                    }
                    selectedOptions {
                      name
                      value
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static const String getHomeHero = r'''
    query GetHomeHero {
      metaobjects(type: "home_hero", first: 1) {
        nodes {
          id
          handle
          fields {
            key
            value
            reference {
              ... on MediaImage {
                image {
                  url
                  altText
                }
              }
            }
          }
        }
      }
    }
  ''';

  static const String cartFragment = r'''
    fragment CartFields on Cart {
      id
      totalQuantity
      checkoutUrl
      cost {
        subtotalAmount {
          amount
          currencyCode
        }
        totalAmount {
          amount
          currencyCode
        }
        totalTaxAmount {
          amount
          currencyCode
        }
        totalDutyAmount {
          amount
          currencyCode
        }
      }
      lines(first: 100) {
        nodes {
          id
          quantity
          merchandise {
            ... on ProductVariant {
              id
              title
              product {
                id
                title
                handle
                images(first: 1) {
                  nodes {
                    url
                    altText
                  }
                }
              }
              selectedOptions {
                name
                value
              }
              price {
                amount
                currencyCode
              }
              compareAtPrice {
                amount
                currencyCode
              }
              image {
                url
                altText
              }
            }
          }
        }
      }
    }
  ''';

  static const String getCart =
      r'''
    query GetCart($id: ID!) {
      cart(id: $id) {
        ...CartFields
      }
    }
  ''' +
      cartFragment;

  static const String cartCreate =
      r'''
    mutation CartCreate($input: CartInput!) {
      cartCreate(input: $input) {
        cart {
          ...CartFields
        }
        userErrors {
          field
          message
          code
        }
        warnings {
          message
          code
        }
      }
    }
  ''' +
      cartFragment;

  static const String cartLinesAdd =
      r'''
    mutation CartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
      cartLinesAdd(cartId: $cartId, lines: $lines) {
        cart {
          ...CartFields
        }
        userErrors {
          field
          message
          code
        }
        warnings {
          message
          code
        }
      }
    }
  ''' +
      cartFragment;

  static const String cartLinesUpdate =
      r'''
    mutation CartLinesUpdate($cartId: ID!, $lines: [CartLineUpdateInput!]!) {
      cartLinesUpdate(cartId: $cartId, lines: $lines) {
        cart {
          ...CartFields
        }
        userErrors {
          field
          message
          code
        }
        warnings {
          message
          code
        }
      }
    }
  ''' +
      cartFragment;

  static const String cartLinesRemove =
      r'''
    mutation CartLinesRemove($cartId: ID!, $lineIds: [ID!]!) {
      cartLinesRemove(cartId: $cartId, lineIds: $lineIds) {
        cart {
          ...CartFields
        }
        userErrors {
          field
          message
          code
        }
        warnings {
          message
          code
        }
      }
    }
  ''' +
      cartFragment;
}
