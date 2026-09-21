cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2216"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2216/agentshield_0.2.2216_darwin_amd64.tar.gz"
      sha256 "b32ceedd4568940bbc500065cade4e5bfeb14aa60b1c383f3b348f35976ace99"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2216/agentshield_0.2.2216_darwin_arm64.tar.gz"
      sha256 "2108e8630390e62c66f937346d2d1722cdb096a19b38a5864253619a09fc5c16"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2216/agentshield_0.2.2216_linux_amd64.tar.gz"
      sha256 "aa020f1c2e2309578fdc964c634e5ebf4bed560f333a4d6e17a9e06acca5830a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2216/agentshield_0.2.2216_linux_arm64.tar.gz"
      sha256 "663117c6314c43830cfab20e1ac5e8fa3695b03721ef393fc864dc42d43867ff"
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
