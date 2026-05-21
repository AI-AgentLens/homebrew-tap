cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1060"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1060/agentshield_0.2.1060_darwin_amd64.tar.gz"
      sha256 "8854502bc9a4ad46c927f4052ddeb14c9586bf304be9cad3ff9533e6ec984f4b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1060/agentshield_0.2.1060_darwin_arm64.tar.gz"
      sha256 "db7649ef24f1b776ad591b981f0a174e1bcddc72520ccca94e8794e6b4604ba0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1060/agentshield_0.2.1060_linux_amd64.tar.gz"
      sha256 "5c8d224fd46aef87656667572d0c9b78fb9006567b7af895d0bf935f23cbed9d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1060/agentshield_0.2.1060_linux_arm64.tar.gz"
      sha256 "3ba4ac2676544aca1f5679566fc32724f4999d1a303d517ebacce2ab097f1abc"
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
