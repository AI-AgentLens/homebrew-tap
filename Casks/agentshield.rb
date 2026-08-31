cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1999"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1999/agentshield_0.2.1999_darwin_amd64.tar.gz"
      sha256 "6f72257121167be1cc2f3ae0e74ea015bf8635ca5915fb142ac26bfe18544ed0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1999/agentshield_0.2.1999_darwin_arm64.tar.gz"
      sha256 "4e9702d62f8e5ce46c0040c8070ad879e077e8237af88d2f3c8cf021aef664ed"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1999/agentshield_0.2.1999_linux_amd64.tar.gz"
      sha256 "ef501cd281aa7e8312436cc0d3dbfecf148a086512ee5884ae76ff0137b04b15"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1999/agentshield_0.2.1999_linux_arm64.tar.gz"
      sha256 "13b061d74fb80d270f2933e8a07c36721d4f2e256b48890fe2e964a4145c2df2"
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
