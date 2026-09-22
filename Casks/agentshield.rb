cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2224"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2224/agentshield_0.2.2224_darwin_amd64.tar.gz"
      sha256 "ebe560f53aa29c7bf5139c2aaeb5d153502cd45120a559fc890b7e6a449fc69c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2224/agentshield_0.2.2224_darwin_arm64.tar.gz"
      sha256 "40a91c6d03fb0463541a400da45790037a9e8e2631b3b39c31b2144b7fc37691"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2224/agentshield_0.2.2224_linux_amd64.tar.gz"
      sha256 "c79857c3147bba993d013d37dccd073cc8d23e5ce24ab68c4669f57ac53d3506"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2224/agentshield_0.2.2224_linux_arm64.tar.gz"
      sha256 "2fa4f4384d5145e63ffe1910792a78a75afb10d120fc84b7cd9ec5d53a64e515"
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
