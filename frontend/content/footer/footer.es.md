+++
title =  "Footer"
type = "footer"
draft = true
+++


{{< contact-section
    sectionId="contacto"
    title="Contáctame" 
    contact_form_name="Tu nombre"
    contact_form_email="Tu correo"
    contact_form_message="Tu mensaje"
    contact_button="Enviar mensaje"
    contact_phone_title="Mi teléfono"
    contact_phone_number="<a href='tel:+555666777'>555 666 777</a>"
    contact_email_title="Mi correo"
    contact_email_email="demo@demosite.com"
    contact_address_title="Mi ubicación"
    contact_address_address="🇩🇰 Denmark"
    form_action="https://formspree.io/f/mail@example.com"
    form_method="POST"
>}}

{{< newsletter-section 
    newsletter_title="Subscríbete"
    newsletter_placeholder="Tu correo"
    newsletter_button="Subscríbete"
    newsletter_success_message="Gracias por suscribirte!"
    newsletter_error_message="Algo ha fallado, por favor inténtalo de nuevo."
    newsletter_note="Respetamos tu privacidad."
    form_action="/"
    form_method="POST"
>}}


{{< text-section
title="Contenido extra"
centered="true"
>}}

Puedes añadir contenido adicional después de los bloques de `section`.

Aquí puedes ser creativo, utilizar otros shortcodes, ... O dejarlo vacío.

Para añadir texto que quede bien en el pie, puedes utilizar el shortcode `text-section`.

{{< /text-section >}}
