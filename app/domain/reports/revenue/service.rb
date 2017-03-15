# encoding: utf-8

module Reports::Revenue
  class Service < Base

    self.grouping_model = ::Service
    self.grouping_fk = :service_id

    def load_entries
      super.where(active: true)
    end

    def load_ordertimes(period = past_period)
      super
        .joins(work_item: { accounting_post: :service })
        .where('service_id IS NULL OR services.active = TRUE')
    end

    def load_plannings(period)
      super
        .joins(work_item: { accounting_post: :service })
        .where('service_id IS NULL OR services.active = TRUE')
    end


  end
end