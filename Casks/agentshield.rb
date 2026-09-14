cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2143"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2143/agentshield_0.2.2143_darwin_amd64.tar.gz"
      sha256 "232aa46d31c500fd42d07af2e1433eaf2880065cf2c8279c2bc29a88abe7399a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2143/agentshield_0.2.2143_darwin_arm64.tar.gz"
      sha256 "83d48921532bea0005e9ba6f18ae733b9da037ff58328f0170acf66399473c92"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2143/agentshield_0.2.2143_linux_amd64.tar.gz"
      sha256 "42ea591cdba4e1fecec7b04e759b812d16097699e1a07e62f7549c2af76ec016"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2143/agentshield_0.2.2143_linux_arm64.tar.gz"
      sha256 "2e04b32ea8b8b6a9a2d14edb20499e8b10590e2dc54e1fb855f5360a9d300f86"
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
