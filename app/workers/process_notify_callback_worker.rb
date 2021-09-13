class ProcessNotifyCallbackWorker
  include Sidekiq::Worker
  include SafePerformAsync

  sidekiq_options queue: :low_priority

  def perform(params)
    ProcessNotifyCallback.new(
      notify_reference: params.fetch('reference'),
      status: params.fetch('status'),
    ).call
  end
end
