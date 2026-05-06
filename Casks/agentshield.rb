cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.887"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.887/agentshield_0.2.887_darwin_amd64.tar.gz"
      sha256 "8ce04d401b3b75565cc930d4d1a962177c52a602479ba973c412e44bbd587914"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.887/agentshield_0.2.887_darwin_arm64.tar.gz"
      sha256 "51330a5d0956deb715a9e85c9c856a56f1f2812582ca05170c037535b13c779e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.887/agentshield_0.2.887_linux_amd64.tar.gz"
      sha256 "379f8e5a02aea4c2431a08f58d2e145072b7dc48cd30793bf53dcfca1191a2ad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.887/agentshield_0.2.887_linux_arm64.tar.gz"
      sha256 "509b9eab85e89f21bdb22754cb709934701ad6325773909f99298889d509ecbe"
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
