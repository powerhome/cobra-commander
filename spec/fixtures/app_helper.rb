# frozen_string_literal: true

class AppHelper
  class << self
    def root
      File.expand_path(
        "./app",
        File.dirname(__FILE__)
      )
    end

    def tree # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      {
        name: "App",
        path: root,
        ancestry: Set.new,
        dependencies: [
          {
            name: "a",
            path: "#{root}/components/a",
            ancestry: Set.new(
              [
                { name: "App", path: root },
              ]
            ),
            dependencies: [
              {
                name: "b",
                path: "#{root}/components/b",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "a", path: "#{root}/components/a" },
                  ]
                ),
                dependencies: [],
              },
              {
                name: "c",
                path: "#{root}/components/c",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "a", path: "#{root}/components/a" },
                  ]
                ),
                dependencies: [
                  {
                    name: "b",
                    path: "#{root}/components/b",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root },
                        { name: "a", path: "#{root}/components/a" },
                        { name: "c", path: "#{root}/components/c" },
                      ]
                    ),
                    dependencies: [],
                  },
                ],
              },
            ],
          },
          {
            name: "d",
            path: "#{root}/components/d",
            ancestry: Set.new(
              [
                { name: "App", path: root },
              ]
            ),
            dependencies: [
              {
                name: "b",
                path: "#{root}/components/b",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "d", path: "#{root}/components/d" },
                  ]
                ),
                dependencies: [],
              },
              {
                name: "c",
                path: "#{root}/components/c",
                ancestry: Set.new(
                  [
                    { name: "App", path: root },
                    { name: "d", path: "#{root}/components/d" },
                  ]
                ),
                dependencies: [
                  {
                    name: "b",
                    path: "#{root}/components/b",
                    ancestry: Set.new(
                      [
                        { name: "App", path: root },
                        { name: "d", path: "#{root}/components/d" },
                        { name: "c", path: "#{root}/components/c" },
                      ]
                    ),
                    dependencies: [],
                  },
                ],
              },
            ],
          },
        ],
      }
    end
  end
end
