module DataMigrations
  class DestroyOrphanedSites
    TIMESTAMP = 20220620110204
    MANUAL_RUN = true

    def change
      orphaned_sites = TempSite.left_outer_joins(:course_options).where(course_options: { id: nil }).distinct
      orphaned_sites.destroy_all
    end
  end
end
