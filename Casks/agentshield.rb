cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1822"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1822/agentshield_0.2.1822_darwin_amd64.tar.gz"
      sha256 "ee2a6d5ac2bd4424f0e9503246bfab87ccd4b76d8e42fed6dd8fb0a2371a1290"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1822/agentshield_0.2.1822_darwin_arm64.tar.gz"
      sha256 "ba565e1c939ce2caf275cba521195b4b7adc4687fa9aca9aeb733eb77fa6ec32"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1822/agentshield_0.2.1822_linux_amd64.tar.gz"
      sha256 "f2383ed0840f6d6bf56b0f19b4738769a4ebc54fb3013dbf96e6a1dd4064c273"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1822/agentshield_0.2.1822_linux_arm64.tar.gz"
      sha256 "c8c0f69fee6b8348ccec4ac26b72777eb61b752c67ae9f044ae354bd0ecaea37"
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
