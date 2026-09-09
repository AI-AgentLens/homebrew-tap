cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2100"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2100/agentshield_0.2.2100_darwin_amd64.tar.gz"
      sha256 "8c49579c3b3b4d5e6634f8b4431fb1602c76dfedac894efebf3a1a94943dc6d1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2100/agentshield_0.2.2100_darwin_arm64.tar.gz"
      sha256 "ed41acaec73ca86f2860a18db1bb06e43e2edef43cc34ee4d3ab32523c7e2f80"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2100/agentshield_0.2.2100_linux_amd64.tar.gz"
      sha256 "56bdfb988f256f284a81a4f4c29255722b7afee0fd51dde3b36a538a12ba9522"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2100/agentshield_0.2.2100_linux_arm64.tar.gz"
      sha256 "3db2bb8c38d89406a26e433879a9e355f858a5946cd1c4e6559e5db496646134"
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
