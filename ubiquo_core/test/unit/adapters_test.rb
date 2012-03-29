require File.dirname(__FILE__) + "/../test_helper.rb"

class Ubiquo::AdaptersTest < ActiveSupport::TestCase
  def test_sequences
    ActiveRecord::Base.connection.create_sequence(:test)
    (1..10).each do |i|
      assert_equal i, ActiveRecord::Base.connection.next_val_sequence(:test)
    end

    ActiveRecord::Base.connection.drop_sequence(:test)
    exceptions = [ActiveRecord::StatementInvalid]
    exceptions << ActiveRecord::JDBCError if ActiveRecord.const_defined?(:JDBCError)
    assert_raise *exceptions do
      ActiveRecord::Base.connection.next_val_sequence(:test)
    end
  end

  def test_create_sequence
    ActiveRecord::Base.connection.expects(:create_sequence).with("test_$_content_id").once

    definition = nil
    ActiveRecord::Base.connection.create_table(:test, :force => true){|table|
      definition = table
      table.sequence :test, :content_id
    }
    ActiveRecord::Base.connection.drop_table(:test)
    assert_not_nil definition[:content_id]
  end

  def test_create_sequence_in_change_table
    ActiveRecord::Base.connection.expects(:create_sequence).with("test_$_content_id").once
    ActiveRecord::Base.connection.create_table(:test, :force => true){}
    ActiveRecord::Base.connection.change_table(:test) do |table|
      table.sequence :test, :content_id
    end
    ActiveRecord::Base.connection.drop_table(:test)
  end

  def test_gets_sequences_list
    ActiveRecord::Base.connection.create_table(:test, :force => true){|table|
      table.sequence :test, :content_id
    }
    assert ActiveRecord::Base.connection.list_sequences("test_").include?('test_$_content_id')
    ActiveRecord::Base.connection.drop_table(:test)
  end

  def test_drop_created_sequences
    ActiveRecord::Base.connection.create_table(:test, :force => true){|table|
      table.sequence :test, :content_id
    }
    assert ActiveRecord::Base.connection.list_sequences("test_").include?('test_$_content_id')

    ActiveRecord::Base.connection.drop_table(:test)
    assert !ActiveRecord::Base.connection.list_sequences("test_").include?('test_$_content_id')

  end

  def test_reset_sequence_value
    ActiveRecord::Base.connection.create_table(:test, :force => true){|table|
      table.sequence :test, :content_id
    }

    ActiveRecord::Base.connection.reset_sequence_value('test_$_content_id', 5)
    assert_equal 5, ActiveRecord::Base.connection.next_val_sequence('test_$_content_id')

    ActiveRecord::Base.connection.reset_sequence_value('test_$_content_id')
    assert_equal 1, ActiveRecord::Base.connection.next_val_sequence('test_$_content_id')

    ActiveRecord::Base.connection.execute("INSERT INTO test (content_id) VALUES (10)")
    ActiveRecord::Base.connection.reset_sequence_value('test_$_content_id')
    assert_equal 11, ActiveRecord::Base.connection.next_val_sequence('test_$_content_id')

    ActiveRecord::Base.connection.drop_table(:test)
  end

  def test_should_exist_sequences_after_create
    ActiveRecord::Base.connection.create_table(:test, :force => true){|table|
      table.sequence :test, :content_id
    }
    assert ActiveRecord::Base.connection.list_sequences("test_").include?("test_$_content_id")
  end

  def test_should_exist_sequence_and_field_after_add_sequence_field
    connection = ActiveRecord::Base.connection
    connection.create_table(:test, :force => true){}
    connection.add_sequence_field :test, :content_id
    assert connection.list_sequences("test_").include?("test_$_content_id")
    column_names = connection.columns('test').map(&:name).map(&:to_s)
    assert column_names.include?('content_id')
    connection.drop_table(:test)
  end

  def test_should_not_exist_sequences_after_remove_sequence_in_change_table
    ActiveRecord::Base.connection.create_table(:test, :force => true){|table|
      table.sequence :test, :content_id
    }
    ActiveRecord::Base.connection.change_table(:test){|table|
      table.remove_sequence :test, :content_id
    }
    assert !ActiveRecord::Base.connection.list_sequences("test_").include?("test_$_content_id")
    ActiveRecord::Base.connection.drop_table(:test)
  end

  def test_should_not_exist_sequences_after_remove_sequence_field
    ActiveRecord::Base.connection.create_table(:test, :force => true){|table|
      table.sequence :test, :content_id
    }
    ActiveRecord::Base.connection.remove_sequence_field :test, :content_id
    assert !ActiveRecord::Base.connection.list_sequences("test_").include?("test_$_content_id")
    ActiveRecord::Base.connection.drop_table(:test)
  end

  def test_create_table_with_force_and_dropping_does_not_deletes_fresh_sequences
    ActiveRecord::Base.connection.create_table(:test, :force => true){}
    ActiveRecord::Base.connection.create_table(:test, :force => true){|table|
      table.sequence :test, :content_id
    }
    assert ActiveRecord::Base.connection.list_sequences("test_").include?("test_$_content_id")
  end

end
