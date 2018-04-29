//= require ./vendors/sweetalert.min

document.addEventListener('rails:attachBindings', function(el) {
  function handleConfirm(el) {
    if (!allowAction(this)) {
      Rails.stopEverything(el);
    }
  }

  function allowAction(el) {
    if ($(el).data('confirmSwal') == null) {
      return true;
    }

    showConfirmationDialog(el);
    return false;
  }

  function showConfirmationDialog(el) {
    var message = $(el).data('confirmSwal');
    swal({
      icon: 'warning',
      dangerMode: true,
      buttons: [I18n.t('cancel'), I18n.t('delete')],
      title: message || I18n.t('are_you_sure'),
      text: I18n.t('do_you_want_to_delete'),
    }).then(function(result) {
      confirmed(el, result);
    });
  }

  function confirmed(el, result) {
    if (result) {
      $(el).data('confirmSwal', null);
      el.click();
    }
  }

  Rails.delegate(document, 'a[data-confirm-swal]', 'click', handleConfirm);
});
