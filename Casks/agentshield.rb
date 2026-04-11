cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.539"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.539/agentshield_0.2.539_darwin_amd64.tar.gz"
      sha256 "da06fe8b44603e70aa69f17d056ba0e2e1db42f2bcacbedf3fd20d6e70b90b64"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.539/agentshield_0.2.539_darwin_arm64.tar.gz"
      sha256 "f3639d5d854739320049f08767dd228e13952abf6e00904a071269b8161ceefd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.539/agentshield_0.2.539_linux_amd64.tar.gz"
      sha256 "645f515af08be0c67e002968280e72b3b199cbacb3edd7972b25218a4c1244ae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.539/agentshield_0.2.539_linux_arm64.tar.gz"
      sha256 "eba7ce1071650de2df9025bbf16c3dabed7109650afc1441f8646071a2f83190"
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
