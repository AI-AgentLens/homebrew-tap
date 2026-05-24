cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1112"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1112/agentshield_0.2.1112_darwin_amd64.tar.gz"
      sha256 "64c81e2645b9ec9cbd79a1bee762f4ed88b67001c4f65057b13b3b4d981c7f26"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1112/agentshield_0.2.1112_darwin_arm64.tar.gz"
      sha256 "cfcc1884e5a2ac4cf55cc37ec5eaa188d59b121281f8ec57f3c71aea4b693cb2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1112/agentshield_0.2.1112_linux_amd64.tar.gz"
      sha256 "16c3144e9ab23de5b50a8bc10a93b63be081661b07f719d031235034ff9c1d74"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1112/agentshield_0.2.1112_linux_arm64.tar.gz"
      sha256 "64bdc947f72821e173cff49b596614ebb4dc4432f3462ebd2bbcca9b01d699b9"
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
