<?php
/* Catálogo WooCommerce sem checkout ou coleta de dados pessoais. */
if (!defined('ABSPATH')) { http_response_code(404); exit; }
?>
<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title><?php echo esc_html(get_bloginfo('name')); ?> · Catálogo acadêmico</title><link rel="stylesheet" href="<?php echo esc_url(get_stylesheet_uri()); ?>"></head><body>
<header><a class="brand" href="<?php echo esc_url(home_url('/')); ?>">ABC <span>Place</span></a><span class="label">Projeto do Grupo 09</span></header>
<main><section class="hero"><div><p class="eyebrow">CONTINUIDADE DOS ROTEIROS DE CIBERSEGURANÇA</p><h1>A mesma loja.<br>Uma evolução segura.</h1><p>Catálogo demonstrativo da ABC Place em WordPress e WooCommerce, com aplicação e banco privados na AWS.</p></div><aside class="panel"><strong>ABC Place<br>2026.2</strong><span>Vitor · Artur Cruz · Daniel Juho<br>VPN, WAF e monitoramento Wazuh</span></aside></section>
<section aria-labelledby="catalog-title"><div class="catalog-title"><div><p class="eyebrow">CATÁLOGO DE DEMONSTRAÇÃO</p><h2 id="catalog-title">Produtos do projeto</h2></div><form class="search" method="get" action="<?php echo esc_url(home_url('/')); ?>"><label for="search">Buscar produto</label><div><input id="search" name="s" maxlength="120" value="<?php echo esc_attr(get_search_query()); ?>"><button type="submit">Buscar</button></div></form></div>
<div class="products"><?php
$query = new WP_Query(['post_type'=>'product','post_status'=>'publish','posts_per_page'=>12,'s'=>get_search_query(),'orderby'=>'ID','order'=>'ASC']);
$n=0;while($query->have_posts()):$query->the_post();$product=wc_get_product(get_the_ID());if(!$product)continue;$n++;
?><article class="product"><div class="visual" aria-hidden="true"><?php echo esc_html(sprintf('%02d',$n)); ?></div><div class="details"><h3><?php the_title(); ?></h3><div class="price"><?php echo wp_kses_post($product->get_price_html()); ?></div></div></article><?php endwhile;wp_reset_postdata();if(!$n): ?><p>Nenhum produto encontrado.</p><?php endif; ?></div>
</section><p class="note">Ambiente acadêmico com três produtos sintéticos. Sem pagamentos, cadastro de clientes ou pedidos. O domínio abcplace.blog.br e os servidores dos roteiros anteriores foram preservados; esta é uma implantação de evolução separada.</p></main><footer><span>ABC Place · Cibersegurança</span><span>Grupo 09 · Vitor, Artur Cruz e Daniel Juho</span></footer></body></html>
