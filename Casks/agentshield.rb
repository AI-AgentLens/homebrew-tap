cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1281"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1281/agentshield_0.2.1281_darwin_amd64.tar.gz"
      sha256 "ba2d56d3764b46e6aea7433700b7856ce7c34bd81c6e063c6826ee794d5524f1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1281/agentshield_0.2.1281_darwin_arm64.tar.gz"
      sha256 "e265912a9787faccf201e8353e101969ef684b1691cf401729d7a34b10cf13cd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1281/agentshield_0.2.1281_linux_amd64.tar.gz"
      sha256 "002a50bfc4859ed620e4f02f2e315699aec06cb2b2c9c1f9a4df3b8b0f52b7c3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1281/agentshield_0.2.1281_linux_arm64.tar.gz"
      sha256 "7d10e1fe7799978dc5dfa55febb5a59d777dd5c8f402c16e8f5ad874adb7db9d"
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
