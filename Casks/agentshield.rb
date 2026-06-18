cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1358"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1358/agentshield_0.2.1358_darwin_amd64.tar.gz"
      sha256 "8c45d8ea0273a92fe56326e4a4cde6c0b339f3d990d78fe6067b75c6272f8dcf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1358/agentshield_0.2.1358_darwin_arm64.tar.gz"
      sha256 "3c2fa15181131f1076e32877984e8cd49742f761e721247e6ab2f1cbb633cd15"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1358/agentshield_0.2.1358_linux_amd64.tar.gz"
      sha256 "e266747e8892913e6484a48d07c65d2c2fe49bdadbfa80125902dca8fab045e1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1358/agentshield_0.2.1358_linux_arm64.tar.gz"
      sha256 "847dfc61464e88f9476d1adcba42922f95888f2138adea8bf6c6bc34f7015f3a"
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
