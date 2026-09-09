cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2094"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2094/agentshield_0.2.2094_darwin_amd64.tar.gz"
      sha256 "d1f7c278875cd76ee7d057b9f44c0fcde2b785cacfcc484a17e28686be5a4934"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2094/agentshield_0.2.2094_darwin_arm64.tar.gz"
      sha256 "af5001e6d368f995c2440fd6e5c79511be15d8181e84df71ec44e3f677f29eab"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2094/agentshield_0.2.2094_linux_amd64.tar.gz"
      sha256 "32702d6546ca4adbd75a8c77ffd05c309b098323e5595caf9a536cadf66c7dc6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2094/agentshield_0.2.2094_linux_arm64.tar.gz"
      sha256 "f6e29a55d3c486e48b44dd1e214a71ec9ffc0d694ceda391aa963117a94cded4"
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
