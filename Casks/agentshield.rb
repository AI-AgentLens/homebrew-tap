cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1628"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1628/agentshield_0.2.1628_darwin_amd64.tar.gz"
      sha256 "e9c57710c980ace059ef33b4ef6c9f09045242563a475742e638ab9758539a69"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1628/agentshield_0.2.1628_darwin_arm64.tar.gz"
      sha256 "d818efd8a5666326a87b3379726cfff04844d9d95ab07849561411606fad6bb9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1628/agentshield_0.2.1628_linux_amd64.tar.gz"
      sha256 "1bc136eb173b9c2a51507dc3bb70b097aa60b9989f93835c0cbbcbf589c59b9e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1628/agentshield_0.2.1628_linux_arm64.tar.gz"
      sha256 "af3c4ff60c24703b8cd65f62bf82c16601635854ef9197f42fe48e831313a677"
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
