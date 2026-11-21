const form = document.querySelector('#search-form');
const products = document.querySelector('#products');
const status = document.querySelector('#status');
const currency = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' });
async function load(search = '') {
  status.textContent = 'Carregando catálogo…';
  products.replaceChildren();
  try {
    const response = await fetch(`/api/products?${new URLSearchParams({ search })}`);
    if (!response.ok) throw new Error('catalog_unavailable');
    const data = await response.json();
    for (const item of data.products) {
      const card = document.createElement('article'); card.className = 'product';
      const art = document.createElement('div'); art.className = 'product-visual'; art.setAttribute('aria-hidden', 'true'); art.textContent = `0${item.id}`;
      const details = document.createElement('div');
      const title = document.createElement('h3'); title.textContent = item.name;
      const price = document.createElement('span'); price.className = 'price'; price.textContent = currency.format(item.price_cents / 100);
      details.append(title, price); card.append(art, details); products.append(card);
    }
    status.textContent = data.products.length ? `${data.products.length} produtos encontrados` : 'Nenhum produto encontrado';
  } catch {
    status.textContent = 'O catálogo está indisponível no momento. Tente novamente em instantes.';
  }
}
form.addEventListener('submit', event => { event.preventDefault(); load(document.querySelector('#search').value); });
load();
