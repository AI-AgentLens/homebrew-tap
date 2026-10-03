cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2322"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2322/agentshield_0.2.2322_darwin_amd64.tar.gz"
      sha256 "a8a2f3d3e5ff9eda426077fbcf7f08090978432e6857f131cd6d3264a4e31e42"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2322/agentshield_0.2.2322_darwin_arm64.tar.gz"
      sha256 "ecc185a0acd790f0790ab9a6824ed9eddd99ae0044db139acb4df2961e598e23"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2322/agentshield_0.2.2322_linux_amd64.tar.gz"
      sha256 "98d4e25ade20f5c625207a9b83710b4de864dcca94ef90d0b8baca76439b89aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2322/agentshield_0.2.2322_linux_arm64.tar.gz"
      sha256 "8a696e8afa67f13d3f2baa8d6623b151fa93bff7adc9c840801c93a12df72ac6"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
