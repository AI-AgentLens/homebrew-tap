cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1776"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1776/agentshield_0.2.1776_darwin_amd64.tar.gz"
      sha256 "176e63279ef99206d99132116ea1991f69eaaad8c2956cd1562042adab817023"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1776/agentshield_0.2.1776_darwin_arm64.tar.gz"
      sha256 "6b1778d6a9a1faf7a4f0f2868867326dd915ebcad047dd7afef2285d4126612c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1776/agentshield_0.2.1776_linux_amd64.tar.gz"
      sha256 "95f950bf19d6ec3062bb74f0576ed4d341d789b46fede4af50b85a0d3679fc67"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1776/agentshield_0.2.1776_linux_arm64.tar.gz"
      sha256 "7b0cf969dc18b69a42f73f78dcf1ea8b96fa26f63a6e69eab5417893799705e3"
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
